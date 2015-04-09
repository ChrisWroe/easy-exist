module EasyExist

	# Module for refining TrueClass
	module RefinedTrue
		refine TrueClass do

			# Returns the "yes"/"no" representation of this class
			# @return [String]
			def to_yes_no
				"yes"
			end

		end
	end
end