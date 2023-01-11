%Nay´s segmentations do not contain the images
%add the Victor´s ones

destination_path = 'D:\AtrialsfromNay\atrial_contours_nay\';
source_path = 'E:\NIFTI_Victor_Atrials\';

fid=fopen('log.csv','w'); % Open text file

%get the files of the path
listingDirs = dir(source_path);
[r,s] = size(listingDirs);

%copy the original image in Nay´s directory
for i=3:r
    files_path = strcat(source_path, listingDirs(i).name,'\');
    listingFiles = dir(files_path);
    
    %If the directory is empty continue to next one
    [ri,si] = size(listingFiles );
    if(ri < 3 )
        fprintf('Directory %s is empty \n', listingDirs(i).name);
        continue;
    end

    cd(files_path);

    destination_folder = strcat(destination_path, listingDirs(i).name);
    status = copyfile('la_4ch.nii.gz', destination_folder);
    
end

%Check the ones we do not have the original image and log it
listingDirs = dir(destination_path);
[r,s] = size(listingDirs);

%get the ids in a log that we do not have the original image
for i=3:r
    files_path = strcat(destination_path, listingDirs(i).name,'\');
    listingFiles = dir(files_path);
    
    %If the directory is empty continue to next one
    [ri,si] = size(listingFiles );
    if(ri < 4 )
        fprintf(fid,'%s \n',listingDirs(i).name);
        continue;
    end
end

fclose(fid);
              