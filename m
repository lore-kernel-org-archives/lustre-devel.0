From: Peter Jones <pjones@whamcloud.com>
Date: Thu, 5 Dec 2019 15:30:13 +0000
Subject: [lustre-devel] Lustre 2.13.0 released
Message-ID: <11EBD557-E6ED-4E4B-90F2-88086EAFE1DC@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We are pleased to announce that the Lustre 2.13.0 Release has been declared GA and is available for download<https://downloads.whamcloud.com/public/lustre/lustre-2.13.0/> <https://downloads.hpdd.intel.com/public/lustre/lustre-2.11.0/> . You can also grab the source from git<https://git.whamcloud.com/?p=fs/lustre-release.git;a=commit;h=a298f8c1376485512f83472a22dc755f47947e75>

This major release includes new features:

Persistent Client Cache allows Lustre to utilize client-local storage such as NVMe or NVRAM as part of the filesystem namespace.  Clients can cache the data of newly created or existing files in a locally-mounted cache filesystem (e.g. ext4) for exclusive access at local filesystem speeds, and data migrates transparently into the global filesystem when accessed by other clients  (LU-10092<https://jira.whamcloud.com/browse/LU-10092>)

Multi-Rail Routing enhances multi-rail support for LNet routers, allowing auto discovery of routes and improved resiliency in configurations with multiple interfaces per node (LU-11297<https://jira.whamcloud.com/browse/LU-11297>)

Overstriping allows files to have multiple stripes of a single file on each OST.  This allows configurations with relatively few clients/threads or very large OSTs to better utilize the full storage performance (LU-9846<https://jira.whamcloud.com/browse/LU-9846>)

Self-Extending Layouts improves the flexibility of Progressive File Layouts (PFL) to better handle filesystems with imbalanced OST capacity, such as smaller flash OST pools combined with larger disk OST pools. Files using Self-Extending Layouts can write to the flash pool as much as possible, but will automatically change over to the disk pool if there is not enough space
(LU-10070<https://jira.whamcloud.com/browse/LU-10070>)

Fuller details can be found in the 2.13 wiki page <http://wiki.lustre.org/Release_2.13.0> (including the change log <http://wiki.lustre.org/Lustre_2.13.0_Changelog> and test matrix<http://wiki.lustre.org/Release_2.13.0#Test_Matrix>)

Please log any issues found in the issue tracking system<https://jira.whamcloud.com/>

Thanks to all those who have contributed to the creation of this release.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191205/4774d0b7/attachment.html>
