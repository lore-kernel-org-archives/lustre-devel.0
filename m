From: Jones, Peter A <peter.a.jones@intel.com>
Date: Tue, 3 Apr 2018 20:42:51 +0000
Subject: [lustre-devel] Lustre 2.11.0 released
Message-ID: <0DC149CC-7BA3-4441-BA64-6918876EE119@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We are pleased to announce that the Lustre 2.11.0 Release has been declared GA and is available for <https://downloads.hpdd.intel.com/public/lustre/latest-feature-release/> download<https://downloads.hpdd.intel.com/public/lustre/lustre-2.11.0/> <https://downloads.hpdd.intel.com/public/lustre/lustre-2.11.0/> . You can also grab the source from <http://git.whamcloud.com/fs/lustre-release.git/commit/ea79df5af4d9b034e39caa396cefc2a075e572ba> git<https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=tag;h=refs/tags/2.11.0>

This major release includes new features:

Data on MDT  The Lustre Data on MDT (DoM) feature improves small file IO by placing small files directly on the MDT. It also improves large file IO by avoiding the OST being affected by small random IO that can cause device seeking and hurt the streaming IO performance  (LU-3285<https://jira.hpdd.intel.com/browse/LU-3285>)

File Level Redundancy ?Delayed Resync Provides a mechanism whereby files can be replicated on multiple OSTs in the same namespace, thus strengthening and improving reliability, availability, and aggregate parallel read performance of the data (LU-9771<https://jira.hpdd.intel.com/browse/LU-9771>)

Lock Ahead Enables userspace to request LDLM locks asynchronously thus improving performance for certain workloads (LU-6179<https://jira.hpdd.intel.com/browse/LU-6179>)

Fuller details can be found in the 2.11 wiki page<http://wiki.lustre.org/Release_2.11.0> (including the ch<http://wiki.lustre.org/Lustre_2.11.0_Changelog>ange log<http://wiki.lustre.org/Lustre_2.11.0_Changelog> and test mat<http://wiki.lustre.org/Release_2.11.0#Test_Matrix>rix<http://wiki.lustre.org/Release_2.11.0#Test_Matrix>)

Please log any issues found in the issue tracking system<https://jira.hpdd.intel.com/>

Thanks to all those who have contributed to the creation of this release.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180403/d978c04b/attachment.html>
