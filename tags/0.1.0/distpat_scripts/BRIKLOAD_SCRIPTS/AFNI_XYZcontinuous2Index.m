function [err,Indx] = AFNI_XYZcontinuous2Index (XYZmm, Info, CoordCode, IndexDim)
%
%   [err,Indx] = AFNI_XYZcontinuous2Index (XYZmm, Info, [CoordCode], [IndexDim])
%
%Purpose:
%   Change from voxel XYZ in mm to XYZindex 
%   
%   
%Input Parameters:
%   XYZmm : The continuous coordinates corresponding to Indx
%       The coordnate system output is always in RAI (DICOM) 
%       unless otherwise specified by CoordCode
%   Info is the output of BrikInfo
%   CoordCode is an optional parameter used to specify the coordinates system of XYZmm
%      if empty or not specified, the default is 'RAI'. The code can be either a string or a vector 
%      of numbers (see AFNI_CoordChange for more on that)
%   IndexDim (3 or 1) is an optional parameter used to specify if Indx is Mx3 or Mx1 vector
%      (see AfniIndex2AfniXYZ for more info)
%   	The default is 3 . If you choose to specify IndexDim, you must specify CoordCode 
%      (you could use an empty string to leave CoordCode to the default)
%   
%Output Parameters:
%   err : 0 No Problem
%       : 1 Mucho Problems
%   Indx an Mx3 matrix or an  Mx1 vector (depending on IndexDim)
%        containing the voxel indices to be
%        transformed to voxel coordinates.  (indices start at 0)
%   
%   
%      
%Key Terms:
%   
%More Info :
%   BrikInfo
%   Test_AFNI_XYZcontinuous2Index
%   AFNI_Index2XYZcontinuous
%   Test_AFNI_Index2XYZcontinuous
%   
%
%     Author : Ziad Saad
%     Date : Thu Sep 7 16:50:38 PDT 2000
%     LBC/NIMH/ National Institutes of Health, Bethesda Maryland


%Define the function name for easy referencing
FuncName = 'AFNI_XYZcontinuous2Index';

%Debug Flag
DBG = 1;

ChangeCoord = 0;
if (nargin > 2)
	if (~isempty(CoordCode)),
		ChangeCoord = 1;
	end
end

ChangeDim = 0;
if (nargin == 4),
	if (~isempty(IndexDim)),
		ChangeDim = 1;
	end
end

%initailize return variables
err = 1;
Indx = [];


Indx = XYZmm;

%make sure coordinate system is RAI
if (ChangeCoord),
	[err, maplocation, mapsign, XYZmm] = AFNI_CoordChange (CoordCode, 'RAI', XYZmm);
end

	%The equations that would change the coordinate system to indices must take the indces in the same
	%RAI permutation that the slices are entered into to3d in (No need to worry about R versus L or A versus P)
	%determine the ordering map to go from any permutation of RAI to RAI
		[maploc(1),jnk] = find(Info.Orientation == 'R');
		[maploc(2),jnk] = find(Info.Orientation == 'A');
		[maploc(3),jnk] = find(Info.Orientation == 'I');

		%pre - Wed May 23 18:20:56 PDT 2001 - WRONG !
		%Indx(:,1) = round( ( XYZmm(:, maploc(1)) - Info.ORIGIN(1) ) ./ Info.DELTA(1) );
		%Indx(:,2) = round( ( XYZmm(:, maploc(2)) - Info.ORIGIN(2) ) ./ Info.DELTA(2) );
		%Indx(:,3) = round( ( XYZmm(:, maploc(3)) - Info.ORIGIN(3) ) ./ Info.DELTA(3) );
		
		%post - Wed May 23 18:20:56 PDT 2001 - CORRECT !
		Indx(:,maploc(1)) = round( ( XYZmm(:, 1) - Info.ORIGIN(maploc(1)) ) ./ Info.DELTA(maploc(1)) );
		Indx(:,maploc(2)) = round( ( XYZmm(:, 2) - Info.ORIGIN(maploc(2)) ) ./ Info.DELTA(maploc(2)) );
		Indx(:,maploc(3)) = round( ( XYZmm(:, 3) - Info.ORIGIN(maploc(3)) ) ./ Info.DELTA(maploc(3)) );
		
		ineg = find(Indx < 0);
		if (~isempty(ineg)), Indx(ineg) = 0; end
		
		[iover] = find(Indx(:,1) >  Info.DATASET_DIMENSIONS(1)-1);
		if (~isempty(iover)), Indx(iover, 1) = Info.DATASET_DIMENSIONS(1)-1;	end
		
		[iover] = find(Indx(:,2) >  Info.DATASET_DIMENSIONS(2)-1);
		if (~isempty(iover)), Indx(iover, 2) = Info.DATASET_DIMENSIONS(2)-1;	end
		
		[iover] = find(Indx(:,3) >  Info.DATASET_DIMENSIONS(3)-1);
		if (~isempty(iover)), Indx(iover, 3) = Info.DATASET_DIMENSIONS(3)-1;	end
		
			
	%Now, if needed, change the Index dimension from Mx3 to Mx1
	if (ChangeDim &	IndexDim == 1),
		 [err, Indx] = AfniXYZ2AfniIndex (Indx, Info.DATASET_DIMENSIONS(1), Info.DATASET_DIMENSIONS(2));  
	end
	
err = 0;
return;
