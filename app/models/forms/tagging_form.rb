module Forms
  class TaggingForm < CreationForm
    include Forms::Form::CustomPage

    write_inheritable_attribute :page, 'tagging'
    write_inheritable_attribute :attributes, [:api, :purpose_uuid, :parent_uuid, :tag_layout_template_uuid, :user_uuid, :substitutions, :offset, :tag_start, :skip]

    validates_presence_of *(self.attributes - [:substitutions])

    class InvalidTagLayout < StandardError; end

    def initialize(*args, &block)
      super
      plate.populate_wells_with_pool
    end

    def substitutions
      tag_substitutions = base_layout
      (@substitutions||{}).each do |old_tag,new_tag|
        tag_substitutions[tag_substitutions.key(old_tag)||old_tag] = new_tag
      end
      tag_substitutions
    end

    def skip?
      skip == '1'
    end

    def base_layout
      base = {}
      return base if tag_start=='0' && !skip?
      wells_mapping.each do |i,_,_|
        initial_tag = tags_by_name[tag_layout_template.name][i]
        column      = (i/8)
        raise InvalidTagLayout if skip? && column.odd? # Odd as we number from 0
        target_tag = initial_tag + tag_start.to_i - ((skip? ? 4:0)*column)
        base[initial_tag.to_s]=target_tag.to_s
      end
      base
    end
    private :base_layout

    def offsets
      last_filled_well = index_by_column_of(filled_wells_in_column_order.last)
      first_filled_well = index_by_column_of(filled_wells_in_column_order.first)
      (first_filled_well...96-index_by_column_of(filled_wells_in_column_order.last)).map{|i| [wells_by_column[i],i]}
    end


    def tag_range
      (0...tag_end).map{|i| [i+1,i]}
    end

    def tag_end
      tag_layout_templates.inject(0){|c,t| c > t.tag_group.tags.count ? c : t.tag_group.tags.count }-index_by_column_of(filled_wells_in_column_order.last)
    end
    private :tag_end

    def filled_wells_in_column_order
      @wells_in_column_order ||= filled_wells.sort {|w,w2| index_by_column_of(w) <=> index_by_column_of(w2) }
    end
    private :filled_wells_in_column_order

    def index_by_column_of(well)
      wells_by_column.index(well.location)
    end
    private :index_by_column_of

    def wells_by_column
      @wells_by_column ||= (1..12).map {|column| ('A'..'H').map {|row| "#{row}#{column}"}}.flatten
    end
    private :wells_by_column

    def generate_layouts_and_groups
      maximum_pool_size = plate.pools.map(&:last).map { |pool| pool['wells'].size }.max

      @tag_layout_templates = api.tag_layout_template.all.map(&:coerce).select { |template|
        (template.tag_group.tags.size >= maximum_pool_size)
      }.sort_by! {|template| Settings.purposes[purpose_uuid].tag_layout_templates.index(template.name)||Settings.purposes[purpose_uuid].tag_layout_templates.length }

      @tag_groups = Hash[
        tag_layout_templates.map do |layout|
          catch(:unacceptable_tag_layout) { [ layout.name, tags_by_row(layout) ] }
        end.compact
      ]

      @tag_layout_templates.delete_if { |template| not @tag_groups.key?(template.name) }
    end
    private :generate_layouts_and_groups

    def tag_layout_templates
      generate_layouts_and_groups unless @tag_layout_templates.present?
      @tag_layout_templates
    end

    def tag_groups
      generate_layouts_and_groups unless @tag_groups.present?
      @tag_groups
    end

    def tags_by_name
      @tags_by_name ||=
        Hash[
          tag_layout_templates.map do |layout|
            catch(:unacceptable_tag_layout) { [ layout.name, layout.tag_group.tags.keys.map(&:to_i).sort ] }
          end
        ]
    end

    # Creates a 96 element array of tags from the tag array passed in.
    # If the input is longer than 96 it takes the first 96 if shorter
    # it loops the elements to make up the 96.
    def first_96_tags(tags)
      Array.new(96) { |i| tags[(i % tags.size)] }
    end

    def structured_well_locations(&block)
      Hash.new.tap do |ordered_wells|
        ('A'..'H').each do |row|
          (1..12).each do |column|
            ordered_wells["#{row}#{column}"] = nil
          end
        end
        yield(ordered_wells)
        ordered_wells.delete_if { |_,v| v.nil? }
      end
    end
    private :structured_well_locations

    def tags_by_row(layout)
      structured_well_locations { |tagged_wells| layout.generate_tag_layout(plate, tagged_wells) }.to_a
    end
    private :tags_by_row

    def create_plate!(&block)

      # Build our transfer map first, so if something goes wrong we don't
      # create unwanted plates
      transfers = transfer_map

      @plate_creation = api.plate_creation.create!(
        :parent        => parent_uuid,
        :child_purpose => purpose_uuid,
        :user          => user_uuid
      )

      api.transfer_template.find(Settings.transfer_templates['Custom pooling']).create!(
        :source      => parent_uuid,
        :destination => @plate_creation.child.uuid,
        :user        => user_uuid,
        :transfers   => transfers
      )

      yield(@plate_creation.child) if block_given?
      true
    end
    private :create_plate!

    def transfer_map
      Hash[filled_wells.map{|w| [w.location, wells_by_column[index_by_column_of(w)+offset.to_i]||invalid_well(w)]}]
    end
    private :transfer_map

    def invalid_well(well)
      raise StandardError, "The well at #{well.location} will be transfered out the bounds of the target plate."
    end
    private :invalid_well

    def create_objects!
      create_plate! do |plate|
        tag_layout_template.create!(
          :plate => plate.uuid,
          :user  => user_uuid,
          :substitutions => substitutions.reject { |_,new_tag| new_tag.blank? }
        )
      end
    end
    private :create_objects!

    def tag_layout_template
      @tag_layout_template ||= api.tag_layout_template.find(tag_layout_template_uuid)
    end
    private :tag_layout_template

    def filled_wells
      @filled_wells ||= labware.wells.reject {|w| w.aliquots.empty?}
    end
    private :filled_wells

    def wells_mapping
      filled_wells.map {|w| [index_by_column_of(w),w.state,w.pool['id']]}
    end
  end
end
