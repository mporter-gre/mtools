# OMERO.mtools
Image analysis application in Matlab working with data in an OMERO server

OMERO.mtools is a suite of tools written in Matlab aimed at streamlining common microscopy image analysis tasks common in life sciences into a single place. A common example of the usage of mtools is to use its BoxIt method to rapidly draw 3D box Regions of Interest (ROIs) around objects to be measured (cells, nuclei...) immunofluorescence images and then use these locations with the Intensity Analysis method. This is a frequently time-consuming workflow which often requires different pieces of software - with an OMERO server [[1](https://www.openmicroscopy.org/omero/)] handling microscope vendor propriatory file types and OMERO.mtools processing images in batches everything is done in one place and is much more efficient.

Binaries of OMERO.mtools can be downloaded from [[2](https://downloads.openmicroscopy.org/mtools/)], matched to the relevant OMERO server version, for Windows and MacOS and usage instruction can be found here [[3](https://www.openmicroscopy.org/omero/features/analyze/)]. All the source code is in this repository and can be run in the Matlab interpreter or compiled using interfaces/ImageAnalysisLogin.m as the main file. The contents of the Associated Files folder should be added to the build. It requires a working OMERO.matlab toolkit [[4](https://www.openmicroscopy.org/omero/downloads/)] matching the version number of the relevant OMERO server in the Matlab Path and its java jars in the JavaClassPath.

If OMERO.mtools is useful in your research, please cite this paper [[5](http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=3437820&tool=pmcentrez&rendertype=abstract)]. A bibliography of published research using OMERO.mtools can be found below.

[1] https://www.openmicroscopy.org/omero/

[2] https://downloads.openmicroscopy.org/mtools/

[3] https://www.openmicroscopy.org/omero/features/analyze/

[4] https://www.openmicroscopy.org/omero/downloads/

[5] Allan, C., Burel, J.-M., Moore, J., Blackburn, C., Linkert, M., Loynton, S., et al. (2012) OMERO: flexible, model-driven data management for experimental biology. Nat Methods 9: 245–53 http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=3437820&tool=pmcentrez&rendertype=abstract.


## Bibliography

Mariano, G., Trunk, K., Williams, D.J., Monlezun, L., Strahl, H., Pitt, S.J., and Coulthurst, S.J. (2019) A family of Type VI secretion system effector proteins that form ion-selective pores. Nat Commun 10 http://dx.doi.org/10.1038/s41467-019-13439-0.

Ostrowski, A., Cianfanelli, F.R., Porter, M., Mariano, G., Peltier, J., Wong, J.J., et al. (2018) Killing with proficiency: Integrated post-translational regulation of an offensive Type VI secretion system. PLoS Pathog 14: 1–25.

Schleicher, K., Porter, M., Have, S. ten, Sundaramoorthy, R., Porter, I.M., and Swedlow, J.R. (2017) The Ndc80 complex targets Bod1 to human mitotic kinetochores. Open Biol 7: 170099 https://royalsocietypublishing.org/doi/10.1098/rsob.170099.

Carvalhal, S., Ribeiro, S.A., Arocena, M., Kasciukovic, T., Temme, A., Koehler, K., et al. (2015) The nucleoporin ALADIN regulates Aurora A localization to ensure robust mitotic spindle formation. Mol Biol Cell 26: 3424–38 http://www.molbiolcell.org/content/26/19/3424.full.
