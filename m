From: Jones, Peter A <peter.a.jones@intel.com>
Date: Tue, 3 Oct 2017 07:30:36 +0000
Subject: [lustre-devel] FW: Lustre 2.10.1 released
In-Reply-To: <E067783F-3593-4EC1-9534-FA4D68B3DAE9@intel.com>
References: <E067783F-3593-4EC1-9534-FA4D68B3DAE9@intel.com>
Message-ID: <4446146B-8BA5-46C3-87D7-A24A22FDBE30@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On 2017-10-02, 11:16 PM, "Jones, Peter A" <peter.a.jones at intel.com<mailto:peter.a.jones@intel.com>> wrote:

We are pleased to announce that the Lustre 2.10.1 Release has been declared GA and is available for download<https://downloads.hpdd.intel.com/public/lustre/lustre-2.10.1/>. You can also grab the source from git<https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=commit;h=4044521770d2258ee0fa998d77830183155e2532>.

Along with a number of useful bug fixes, this maintenance release includes the following notable enhancements over 2.10.0:


  *   RHEL 7.4 support for Lustre Servers and Clients (LU-9816<https://jira.hpdd.intel.com/browse/LU-9816>)


  *   ZFS 0.7.1 is now the default version of ZFS used for the release (LU-8619<https://jira.hpdd.intel.com/browse/LU-8619>)


  *   RHEL 6.9 support for Lustre Clients (LU-9979<https://jira.hpdd.intel.com/browse/LU-9979>)


  *   Ubuntu 16.04 support for Lustre Clients


  *   Patchless server build for ldiskfs is now routinely provided. Note that the patched kernel version must still be used to make use of project quotas


  *   4.9 Kernel support for Lustre client (LU-9183<https://jira.hpdd.intel.com/browse/LU-9183>)


  *   MOFED 4.1 support

Details of changes since 2.10.0<http://wiki.lustre.org/Lustre_2.10.0_Changelog> can be found in the 2.10.1 change log<http://wiki.lustre.org/Lustre_2.10.1_Changelog>.

Please log any issues found in the issue tracking system<https://jira.hpdd.intel.com/>.

Thanks to all those who have contributed to the creation of this release.

We are planning to release Lustre 2.10.2 during Q4.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171003/3bc0cba7/attachment-0001.html>
