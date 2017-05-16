From: Faaland, Olaf P. <faaland1@llnl.gov>
Date: Tue, 16 May 2017 18:03:32 +0000
Subject: [lustre-devel] lctl dl - different devices with same device name
Message-ID: <F46BAA88-7E46-4614-994A-01B5CE909CC1@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

This is regarding Lustre 2.8 FE ? 2.8.0 + backported bug fixes.

Typically our MDS nodes run only a single MDT.  When this is the case, lctl dl produces 25 lines of output:

Osd
Mgc
Mds
Lod
Mdt
Mdd
Lwp
And 19 osp?s ? one for each other lustre target in the file system.

Two of these devices listed, the mdt and the mdd, have the same name.  For example,

4 UP mdt lquake-MDT000f lquake-MDT000f-UUID 327
5 UP mdd lquake-MDT000f lquake-MDT000f-UUID 4

Is it correct that they have the same name?  I ask, because the functions jt_device() calls assume that they can uniquely map from a name to a device number, but in this case that?s not possible.

I could improve the utility code easily enough, but I don?t know if the device names are correct or not.  There?s no evidence the file system isn?t working correctly.

-Olaf
