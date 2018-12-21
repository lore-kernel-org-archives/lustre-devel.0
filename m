From: Peter Jones <pjones@whamcloud.com>
Date: Fri, 21 Dec 2018 23:49:27 +0000
Subject: [lustre-devel] Lustre 2.12.0 released
Message-ID: <04C53321-3AE0-4D22-B0E4-E82A8EF2FDD1@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We are pleased to announce that the Lustre 2.12.0 Release has been declared GA and is available for download<https://downloads.whamcloud.com/public/lustre/lustre-2.12.0/> <https://downloads.hpdd.intel.com/public/lustre/lustre-2.11.0/> . You can also grab the source from git<https://git.whamcloud.com/?p=fs/lustre-release.git;a=tag;h=refs/tags/2.12.0>

This major release includes new features:

DNE Directory Restriping DNE Directory Restriping allows large existing directories to be migrated from a single MDT to stripe over multiple MDTs, which makes it easier to take advantage of adding new MDTs to an existing filesystem or to manually rebalance MDT usage  (LU-4684<https://jira.whamcloud.com/browse/LU-4684>)

Lazy Size on MDT Provides a mechanism whereby approximate file sizes can be quickly returned when scanning the MDT directly via a policy engine when performance is more important than precision (LU-9538<https://jira.whamcloud.com/browse/LU-9538>)

LNet Network Health Provides the option when using multiple LNet interfaces to retry sending RPCs via an alternative network if errors are encountered or messages are lost with the initial request (LU-9120<https://jira.whamcloud.com/browse/LU-9120>)

Fuller details can be found in the 2.12 wiki page <http://wiki.lustre.org/Release_2.12.0> (including the change log <http://wiki.lustre.org/Lustre_2.12.0_Changelog> and test matrix<http://wiki.lustre.org/Release_2.12.0#Test_Matrix>)

Please log any issues found in the issue tracking system<https://jira.whamcloud.com/>

Thanks to all those who have contributed to the creation of this release.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181221/750f9466/attachment.html>
