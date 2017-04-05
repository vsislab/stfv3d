# Video-based pedestrian re-identification by adaptive spatio-temporal appearance model

## Introduction

We consider the temporal alignment problem, in addition to the spatial one,
and propose a new approach that takes the video of a walking person as input and builds a spatio-temporal appearance representation for pedestrian re-identification.

This code has been tested on Windows 7/8 64 bit with Matlab 2016b.

## Demo

1. Download the stfv3d code and unzip.

2. Download the following datasets and put them into the folder '../Dataset/'.

  * [i-LIDS-VID](http://www.eecs.qmul.ac.uk/~xiatian/downloads_qmul_iLIDS-VID_ReID_dataset.html)

  * [PRID 2011](http://lrs.icg.tugraz.at/datasets/prid/)

  * [SDU-VID](http://www.vsislab.com/projects/MLAI/PedestrianRepresentation/)



3. run main.m

## Citing

If you find STFV3D useful in your research, please consider citing:

```
@article{zhang2017video,
  author={Zhang, Wei and Ma, Bingpeng and Liu, Kan and Huang, Rui},
  journal={IEEE Transactions on Image Processing},
  title={Video-Based Pedestrian Re-Identification by Adaptive Spatio-Temporal Appearance Model},
  year={2017},
  volume={26},
  number={4},
  pages={2042-2054},
  ISSN={1057-7149}
}

@inproceedings{liu2015spatio,
  title={A spatio-temporal appearance representation for viceo-based pedestrian re-identification},
  author={Liu, Kan and Ma, Bingpeng and Zhang, Wei and Huang, Rui},
  booktitle={Proceedings of the IEEE International Conference on Computer Vision},
  pages={3810--3818},
  year={2015}
}
```

## License

Copyright (c) 2017, Kan Liu
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
