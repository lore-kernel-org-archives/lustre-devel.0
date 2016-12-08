From: Jones, Peter A <peter.a.jones@intel.com>
Date: Thu, 8 Dec 2016 04:25:57 +0000
Subject: [lustre-devel] Lustre 2.9.0 released
Message-ID: <D46E20D2.EB91C%peter.a.jones@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We are pleased to announce that the Lustre 2.9.0 Release has been declared GA and is available for <https://downloads.hpdd.intel.com/public/lustre/latest-feature-release/> download<https://downloads.hpdd.intel.com/public/lustre/lustre-2.9.0/> <https://downloads.hpdd.intel.com/public/lustre/lustre-2.9.0/> . You can also grab the source from <http://git.whamcloud.com/fs/lustre-release.git/commit/ea79df5af4d9b034e39caa396cefc2a075e572ba> git<https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=commit;h=4258370088ae65a7ec7886334191af6d53c73567>

This major release includes new features:

UID/GID Mapping  Provides the capability to remap user and group IDs based on node address so as to simplify administration when sharing access between security domains   (LU-3291<https://jira.hpdd.intel.com/browse/LU-3291>)
Shared Key Crypto Identifies clients/servers and authenticates/encrypts RPCs  (LU-3289<https://jira.hpdd.intel.com/browse/LU-3289>)
Subdirectory Mounts  Offers the option for clients to be able to mount only a defined subset of the filesystem (LU-29<https://jira.hpdd.intel.com/browse/LU-28>)

Server Side Advise and Hinting A Lustre equivalent of fadvise that provides hints to the server about the nature of the data access (willread, dontreed) so that appropriate steps can be taken. (LU-4931<https://jira.hpdd.intel.com/browse/LU-4931>)

Large Bulk IO Allows the configuration of larger options to be able to get more efficient network/disk IO . (LU-7990<https://jira.hpdd.intel.com/browse/LU-7990>)

Weak Updates Lustre support for weak updates (KMP) has been added. Please note the associated name changes for the RPMs . (LU-5614<https://jira.hpdd.intel.com/browse/LU-5614>)
Fuller details can be found in the 2.9 wiki page<http://wiki.lustre.org/Release_2.9.0> (including the ch<http://wiki.lustre.org/Lustre_2.9.0_Changelog>ange log<http://wiki.lustre.org/Lustre_2.9.0_Changelog> and test mat<http://wiki.lustre.org/Release_2.9.0#Test_Matrix>rix<http://wiki.lustre.org/Release_2.9.0#Test_Matrix>)
The following are known issues in the Lustre 2.9 Release:

LU-8313<https://jira.hpdd.intel.com/browse/LU-8813> ? Deployments using kerberos that have upgraded from an earlier release will need to manually add a?k flag to svcgssd in order to maintain compatibility
LU-8880<https://jira.hpdd.intel.com/browse/LU-8880> ? Kerberos does not behave in a consistent manner when deploying in a DNE configuration
These issues are being actively worked and have proposed fixes under testing and review.
Please log any issues found in the issue tracking system<https://jira.hpdd.intel.com/>
Thanks to all those who have contributed to the creation of this release.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161208/e8bdb7f2/attachment.htm>
