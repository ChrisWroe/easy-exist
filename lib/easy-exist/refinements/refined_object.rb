module EasyExist

	# Module for refining Object
	module RefinedObject
		refine Object do

			# Determine if this object is a boolean. (A TrueClass or a FalseClass)
			# @return [Boolean]
			def is_a_boolean?
				self.is_a?(TrueClass) || self.is_a?(FalseClass)
			end
		end
	end
end