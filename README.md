# OMERO.mtools
Image analysis application in Matlab working with data in an OMERO server

OMERO.mtools is a suite of tools written in Matlab aimed at streamlining microscopy image analysis tasks common in life sciences pulling them into a single place. A common example of the usage of mtools is to use its BoxIt method to rapidly draw 3D box Regions of Interest (ROIs) around objects to be measured (cells, nuclei...) immunofluorescence images and then use these locations with the Intensity Analysis method. This is a frequently time-consuming workflow which often requires different pieces of software - with an OMERO server [[1](https://www.openmicroscopy.org/omero/)] handling microscope vendor propriatory file types and OMERO.mtools processing images in batches everything is done in one place and is much more efficient.

Binaries of OMERO.mtools can be downloaded from [[2](https://downloads.openmicroscopy.org/mtools/)], matched to the relevant OMERO server version, for Windows and MacOS and usage instruction can be found here [[3](https://www.openmicroscopy.org/omero/features/analyze/)]. All the source code is in this repository and can be run in the Matlab interpreter or compiled using interfaces/ImageAnalysisLogin.m as the main file. The contents of the Associated Files folder should be added to the build. It requires a working OMERO.matlab toolkit [[4](https://www.openmicroscopy.org/omero/downloads/)] matching the version number of the relevant OMERO server in the Matlab Path and its java jars in the JavaClassPath.

If OMERO.mtools is useful in your research, please cite this paper [[5](http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=3437820&tool=pmcentrez&rendertype=abstract)]. A list of published research using OMERO.mtools can be found below.

[1] https://www.openmicroscopy.org/omero/

[2] https://downloads.openmicroscopy.org/mtools/

[3] https://www.openmicroscopy.org/omero/features/analyze/

[4] https://www.openmicroscopy.org/omero/downloads/

[5] Allan, C., J.-M. Burel, J. Moore, C. Blackburn, M. Linkert, S. Loynton, D. Macdonald, W.J. Moore, C. Neves, A. Patterson, M. Porter, A. Tarkowska, B. Loranger, J. Avondo, I. Lagerstedt, L. Lianas, S. Leo, K. Hands, R.T. Hay, A. Patwardhan, C. Best, G.J. Kleywegt, G. Zanetti, and J.R. Swedlow. 2012. OMERO: flexible, model-driven data management for experimental biology. Nat. Methods. 9:245–53. doi:10.1038/nmeth.1896.


## Publications using OMERO.mtools

Batie, M., J. Frost, M. Frost, J.W. Wilson, P. Schofield, and S. Rocha. 2019. Hypoxia induces rapid changes to histone methylation and reprograms chromatin. Science (80-. ). 363:1222–1226. doi:10.1126/science.aau5870.

Mariano, G., K. Trunk, D.J. Williams, L. Monlezun, H. Strahl, S.J. Pitt, and S.J. Coulthurst. 2019. A family of Type VI secretion system effector proteins that form ion-selective pores. Nat. Commun. 10. doi:10.1038/s41467-019-13439-0.

Ostrowski, A., F.R. Cianfanelli, M. Porter, G. Mariano, J. Peltier, J.J. Wong, J.R. Swedlow, M. Trost, and S.J. Coulthurst. 2018. Killing with proficiency: Integrated post-translational regulation of an offensive Type VI secretion system. PLoS Pathog. 14:1–25. doi:10.1371/journal.ppat.1007230.

Batie, M., J. Druker, L. D’Ignazio, and S. Rocha. 2017. KDM2 Family Members are Regulated by HIF-1 in Hypoxia. Cells. 6:8. doi:10.3390/cells6010008.

Schleicher, K., M. Porter, S. ten Have, R. Sundaramoorthy, I.M. Porter, and J.R. Swedlow. 2017. The Ndc80 complex targets Bod1 to human mitotic kinetochores. Open Biol. 7:170099. doi:10.1098/rsob.170099.

Platani, M., L. Trinkle-Mulcahy, M. Porter, A.A. Jeyaprakash, and W.C. Earnshaw. 2015. Mio depletion links mTOR regulation to Aurora A and Plk1 activation at mitotic centrosomes. J. Cell Biol. 210:45–62. doi:10.1083/jcb.201410001.

Carvalhal, S., S.A. Ribeiro, M. Arocena, T. Kasciukovic, A. Temme, K. Koehler, A. Huebner, and E.R. Griffis. 2015. The nucleoporin ALADIN regulates Aurora A localization to ensure robust mitotic spindle formation. Mol. Biol. Cell. 26:3424–38. doi:10.1091/mbc.E15-02-0113.
