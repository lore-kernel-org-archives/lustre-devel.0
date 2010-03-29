From: Kent =?iso-8859-1?Q?Engstr=F6m?= <kent@nsc.liu.se>
Date: Mon, 29 Mar 2010 16:57:49 +0200
Subject: [Lustre-devel] Lustre 1.8.2 client, Text file busy
In-Reply-To: <m3iq8fus17.fsf@ceres.nsc.liu.se> ("Kent =?iso-8859-1?Q?Engst?=
	=?iso-8859-1?Q?r=F6m=22's?= message of
	"Mon, 29 Mar 2010 16:22:12 +0200")
References: <m3iq8fus17.fsf@ceres.nsc.liu.se>
Message-ID: <m3vdcftbte.fsf@ceres.nsc.liu.se>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

kent at nsc.liu.se (Kent Engstr?m) writes:
> After an upgrade to Lustre 1.8.2 (patchless client on top of Centos 5.4)
> on one of our compute clusters, we have been getting reports of 
> spurious "Text file busy" messages.
...

[Can reproduce on client running]
> $ uname -r; rpm -q lustre
> 2.6.18-164.15.1.el5
> lustre-1.8.2-2.6.18_164.15.1.el5_201003191115
...
> I also expect that there will be no "Text file busy" error when I revert
> a node on the first cluster to 1.6.7.1 and run the test script, which I
> will proceed to do now.

I have now tested on a node reverted to

$ uname -r; rpm -q lustre
2.6.18-164.11.1.el5
lustre-1.6.7.1-2.6.18_164.11.1.el5_201001202236

On that node, I could not reproduce the problem.


-- 
Kent Engstr?m, National Supercomputer Centre
kent at nsc.liu.se, +46 13 28 4444
