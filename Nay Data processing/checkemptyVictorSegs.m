%Check empty folder of Victor segmentations

source_path = 'E:\NIFTI_Victor_Atrials\';

%fid=fopen('log.csv','w'); % Open text file

%get the files of the path
listingDirs = dir(source_path);
[r,s] = size(listingDirs);

%identify what folders do not contain the 4ch segmentation and print them
for i=3:r
    files_path = strcat(source_path, listingDirs(i).name,'\');
    listingFiles = dir(files_path);
    
    %If the directory is empty continue to next one
    [ri,si] = size(listingFiles );
    isempty= true;
    for j= 1: ri
        if(strcmp(listingFiles(j).name,'la_4ch_aseg.nii.gz'))
          isempty = false;
        end
    end 

    if(isempty == true)
        fprintf("%s\n", listingDirs(i).name);
    end
end


              