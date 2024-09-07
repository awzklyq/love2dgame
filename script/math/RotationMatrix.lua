_G.RotationMatrixs = {}

--/** Builds a rotation matrix given only a XAxis. Y and Z are unspecified but will be orthonormal. XAxis need not be normalized. */
RotationMatrixs.MakeFromX = function(XAxis)

	local NewX = XAxis:Normalize();

	-- try to use up if possible
	local UpVector = ( math.abs(NewX.z) < (1.0 - math.KINDA_SMALL_NUMBER) ) and Vector3.new(0,0,1.0) or Vector3.new(1.0,0,0);

	local NewY = Vector3.cross(UpVector, NewX):Normalize();
	local NewZ = Vector3.cross(NewX , NewY)

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end

RotationMatrixs.MakeFromY = function(YAxis)

	local NewY = YAxis:Normalize();

	-- try to use up if possible
	local UpVector = ( math.abs(NewY.z) < (1.0 - math.KINDA_SMALL_NUMBER) ) and Vector3.new(0,0,1.0) or Vector3.new(1.0,0,0);

	local NewZ = Vector3.cross(UpVector, NewY):Normalize();
	local NewX = Vector3.cross(NewY , NewZ)

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end

RotationMatrixs.MakeFromZ = function(ZAxis)

	local NewZ = ZAxis:Normalize();

	-- try to use up if possible
	local UpVector = ( math.abs(NewZ.z) < (1.0 - math.KINDA_SMALL_NUMBER) ) and Vector3.new(0,0,1.0) or Vector3.new(1.0,0,0);

	local NewX = Vector3.cross(UpVector, NewZ):Normalize();
	local NewY = Vector3.cross(NewZ , NewX)

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end

--/** Builds a matrix with given X and Y axes. X will remain fixed, Y may be changed minimally to enforce orthogonality. Z will be computed. Inputs need not be normalized. */
RotationMatrixs.MakeFromXY = function(XAxis, YAxis)

	local NewX = XAxis:Normalize();
	local Norm = YAxis:Normalize();

	-- if they're almost same, we need to find arbitrary vector
	if  math.IsNearlyEqual(math.abs(Vector3.dot(NewX, Norm)), 1.0) then
	
		--// make sure we don't ever pick the same as NewX
		Norm = ( math.abs(NewX.z) < (1 - math.KINDA_SMALL_NUMBER) ) and Vector3.new(0,0,1) or Vector3.new(1.0,0,0);
    end

	local NewZ = Vector3.cross(NewX, Norm):Normalize();
	local NewY = Vector3.cross(NewZ, NewX);

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end

RotationMatrixs.MakeFromXZ = function(XAxis, ZAxis)
	local NewX = XAxis:Normalize();
	local Norm = ZAxis:Normalize();

	--// if they're almost same, we need to find arbitrary vector
	if math.IsNearlyEqual(math.abs(Vector3.dot(NewX, Norm)), 1.0) then
	
		-- make sure we don't ever pick the same as NewX
		Norm = (math.abs(NewX.z) < (1.0 - math.UE_KINDA_SMALL_NUMBER)) and Vector3.new(0,0,1) or Vector3.new(1.0,0,0);
	end

	local NewY = Vector3.cross(Norm, NewX):Normalize();
	local NewZ = Vector3.cross(NewX, NewY);

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end

RotationMatrixs.MakeFromZX = function(ZAxis, XAxis)
	local NewZ = ZAxis:Normalize();
	local Norm = XAxis:Normalize();

	-- if they're almost same, we need to find arbitrary vector
	if math.IsNearlyEqual(math.abs(Vector3.dot(NewZ ,Norm)), 1.0) then
	
		--// make sure we don't ever pick the same as NewX
		Norm = (math.abs(NewZ.Z) < (1.0 - math.UE_KINDA_SMALL_NUMBER))  and Vector3.new(0,0,1) or Vector3.new(1.0,0,0);
	end

	local NewY = Vector3.cross(NewZ, Norm):Normalize();
	local NewX = Vector3.cross(NewY, NewZ);

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end


RotationMatrixs.MakeFromYZ = function(YAxis, ZAxis)
	local NewY = YAxis:Normalize();
	local Norm = ZAxis:Normalize();

	-- if they're almost same, we need to find arbitrary vector
	if math.IsNearlyEqual(math.abs(Vector3.dot(NewY ,Norm)), 1.0) then
	
		--// make sure we don't ever pick the same as NewX
		Norm = (math.abs(NewY.z) < (1.0 - math.UE_KINDA_SMALL_NUMBER))  and Vector3.new(0,0,1) or Vector3.new(1.0,0,0);
	end

	local NewX = Vector3.cross(NewY, Norm):Normalize();
	local NewZ = Vector3.cross(NewX, NewY);

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end

RotationMatrixs.MakeFromZY = function(ZAxis, YAxis)
	local NewZ = ZAxis:Normalize();
	local Norm = YAxis:Normalize();

	-- if they're almost same, we need to find arbitrary vector
	if math.IsNearlyEqual(math.abs(Vector3.dot(NewZ ,Norm)), 1.0) then
	
		--// make sure we don't ever pick the same as NewX
		Norm = (math.abs(NewZ.z) < (1.0 - math.UE_KINDA_SMALL_NUMBER))  and Vector3.new(0,0,1) or Vector3.new(1.0,0,0);
	end

	local NewX = Vector3.cross(Norm, NewZ):Normalize();
	local NewY = Vector3.cross(NewZ, NewX);

	return Matrix3D.createFromVectors(NewX, NewY, NewZ, Vector3.cOrigin)
end
