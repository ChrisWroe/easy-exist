module EasyExist

	# Module for refining FalseClass
	module RefinedFalse
		refine FalseClass do

			# Returns the "yes"/"no" representation of this class
			# @return [String]
			def to_yes_no
				"no"
			end

		end
	end
end