From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 28 Jan 2020 20:36:24 +0000
Subject: [lustre-devel] Gerrit option - build only one backend
In-Reply-To: <1580240254.12827.0@informatik.uni-hamburg.de>
References: <1580240254.12827.0@informatik.uni-hamburg.de>
Message-ID: <102CE8C0-6E14-44C1-9189-FF8A0C50EE56@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The fstype option affects the testing, because this is "Test-Parameters:", not "Build-Parameters:". :-)

The zfs vs. ldiskfs option mostly only affects the osd-ldiskfs and oss-zfs, and the matching mount.lustre helpers. All of the rest of the code should be independent of the backing filesystem. 

Cheers, Andreas

> On Jan 28, 2020, at 12:37, Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de> wrote:
> 
> ?
> Dear all,
> 
> I am wondering why the Gerrit option "fstype=zfs" in my commit does not influence the build process - both targets, ldiskfs and zfs are built:
> 
> checking whether to build ldiskfs... yes
> checking whether to enable zfs... yes
> 
> The option seems to affect only the following tests. Is this behavior intended?
> Is there any option to build and test only one backend?
> 
> Regards
> Anna
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
