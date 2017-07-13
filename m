From: Jones, Peter A <peter.a.jones@intel.com>
Date: Thu, 13 Jul 2017 21:25:42 +0000
Subject: [lustre-devel] Lustre 2.10.0 released
Message-ID: <D17F6C2E-90D0-4C61-94AE-79C13DB08F75@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We are pleased to announce that the Lustre 2.10.0 Release has been declared GA and is available for <https://downloads.hpdd.intel.com/public/lustre/latest-feature-release/> download<https://downloads.hpdd.intel.com/public/lustre/lustre-2.10.0/> <https://downloads.hpdd.intel.com/public/lustre/lustre-2.10.0/> . You can also grab the source from <http://git.whamcloud.com/fs/lustre-release.git/commit/ea79df5af4d9b034e39caa396cefc2a075e572ba> git<https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=commit;h=58fd06e4d9fcee95f5c60bc8120d782b61f0823c>

This major release includes new features:

Progressive File Layouts  Enables file layouts to automatically adjust as size of files grow thus optimizing performance for diverse workloads    (LU-8898<https://jira.hpdd.intel.com/browse/LU-8998>)

Multi-Rail LNet Allows LNet to utilize multiple network interfaces on a node in parallel, aggregating their performance (LU-7734<https://jira.hpdd.intel.com/browse/LU-7734>)

Project Quotas  Extension to the Lustre quotas feature to provide the option to place quotas on a per project basis rather than just per user or per group (LU-4017<https://jira.hpdd.intel.com/browse/LU-4017>)

Simplified Userspace Snapshots Provides a mechanism to leverage the snapshot capability in OpenZFS to take a coordinated snapshot of a Lustre filesystem. (LU-8900<https://jira.hpdd.intel.com/browse/LU-8900>)

NRS Delay Policy Simulates high server load as a way of validating the resilience of Lustre under load . (LU-6283<https://jira.hpdd.intel.com/browse/LU-6283>)

Fuller details can be found in the 2.10 wiki page<http://wiki.lustre.org/Release_2.10.0> (including the ch<http://wiki.lustre.org/Lustre_2.10.0_Changelog>ange log<http://wiki.lustre.org/Lustre_2.10.0_Changelog> and test mat<http://wiki.lustre.org/Release_2.10.0#Test_Matrix>rix<http://wiki.lustre.org/Release_2.10.0#Test_Matrix>)

Please log any issues found in the issue tracking system<https://jira.hpdd.intel.com/>

Thanks to all those who have contributed to the creation of this release.

This is the first release of the 2.10.x LTS release stream. We are planning to release a freely available Lustre 2.10.1 in the coming weeks

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170713/6eb64259/attachment.htm>
