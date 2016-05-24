module Forms
  class TaggingForm < CreationForm
    include Forms::Form::CustomPage

    write_inheritable_attribute :page, 'tagging'
    write_inheritable_attribute :attributes, [:direction, :walking_by, :api, :purpose_uuid, :parent_uuid, :tag_group_uuid, :user_uuid, :substitutions, :offset, :tag_start]

    validates_presence_of *(self.attributes - [:substitutions])

    class InvalidTagLayout < StandardError; end

    def initialize(*args, &block)
      super
      plate.populate_wells_with_pool
    end

    def substitutions
      @substitutions
    end

    ## TODO: Review tags_by_name[tag_layout_template.name]
    def base_layout
      base = {}
      return base if tag_start=='0'
      send("wells_by_#{direction}_mapping").each do |i,_,_|
        initial_tag = tags_by_name[tag_group.name][i]
        column      = (i/8)
        target_tag = initial_tag + tag_start.to_i
        base[initial_tag.to_s]=target_tag.to_s
      end
      base
    end
    private :base_layout

    def offsets
      last_filled_well = index_by_column_of(filled_wells_in_column_order.last)
      first_filled_well = index_by_column_of(filled_wells_in_column_order.first)
      (first_filled_well..95-last_filled_well).map{|i| [well_location_by_column[i],i-first_filled_well]}
    end


    def tag_range
      (0...tag_end).map{|i| [i+1,i]}
    end

    def tag_end
      (tag_groups.inject(0) do |c,tag_group|
        c > tag_group.tags_keys.length ? c : tag_group.tags_keys.length
      end) - index_by_column_of(filled_wells_in_column_order.last)
    end
    private :tag_end

    def filled_wells_in_column_order
      @wells_in_column_order ||= filled_wells.sort {|w,w2| index_by_column_of(w) <=> index_by_column_of(w2) }
    end
    private :filled_wells_in_column_order

    def index_by_row_of(well)
      well_location_by_row.index(well.location)
    end

    def index_by_column_of(well)
      well_location_by_column.index(well.location)
    end
    private :index_by_column_of

    def well_location_by_column
      @well_location_by_column ||= (1..12).map {|column| ('A'..'H').map {|row| "#{row}#{column}"}}.flatten
    end
    private :well_location_by_column

    def well_location_by_row
      @well_location_by_row ||= ('A'..'H').map {|row| (1..12).map {|column| "#{row}#{column}"}}.flatten
    end
    private :well_location_by_row


    ## TODO: sort_by! for tag_layout_templates
    def generate_layouts_and_groups
      maximum_pool_size = plate.pools.map(&:last).map { |pool| pool['wells'].size }.max

      @tag_groups ||= [].tap do |tag_groups|
        api.tag_group.each do |tag_group|
           tag_groups << Hashie::Mash.new(
             :uuid => tag_group.uuid,
             :name => tag_group.name,
             :tags_keys => tag_group.tags.keys.map(&:to_i).sort
           )
         end
        @tag_groups = tag_groups.select! { |tag_group|
          (tag_group.tags_keys.length >= maximum_pool_size)
        }
      end
    end
    private :generate_layouts_and_groups

    def tag_groups
      generate_layouts_and_groups
      @tag_groups
      #Settings.tag_groups
    end

    def tag_groups_with_uuid
      tag_groups.map {|tag_group| [ tag_group.name, tag_group.uuid ]}
    end

    def tags_by_name
      @tags_by_name ||=
        Hash[
          tag_groups.map do |tag_group|
            catch(:unacceptable_tag_layout) { [ tag_group.name, tag_group.tags_keys ] }
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
      Hash[filled_wells.map{|w| [w.location, well_location_by_column[index_by_column_of(w)+offset.to_i]||invalid_well(w)]}]
    end
    private :transfer_map

    def valid?
      true
    end

    def invalid_well(well)
      raise StandardError, "The well at #{well.location} will be transfered out the bounds of the target plate."
    end
    private :invalid_well

    def create_objects!
      create_plate! do |plate|

        api.tag_layout.create!(
          :user        => user_uuid,
          :plate       => plate.uuid,
          :tag_group   => tag_group_uuid,
          :direction   => direction,
          :walking_by  => walking_by,
          :initial_tag => tag_start,
          :substitutions => substitutions
        )
      end
    end
    private :create_objects!

    def tag_group
      @tag_group ||= api.tag_group.find(tag_group_uuid)
    end
    private :tag_group

    def filled_wells
      @filled_wells ||= labware.wells.reject {|w| w.aliquots.empty?}
    end
    private :filled_wells

    def wells_by_column_mapping
      filled_wells.sort_by {|w| index_by_column_of(w) }.map {|w| [index_by_column_of(w),w.state,w.pool['id']]}
    end
    def wells_by_row_mapping
      filled_wells.sort_by {|w| index_by_row_of(w) }.map {|w| [index_by_row_of(w),w.state,w.pool['id']]}
    end
  end
end
