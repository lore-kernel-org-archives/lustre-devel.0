From: David Dillow <dillowda@ornl.gov>
Date: Thu, 09 Dec 2010 17:15:54 -0500
Subject: [Lustre-devel] Git commit message format
In-Reply-To: <4D0138D8.3000505@cea.fr>
References: <9E373505737CCD46890A96FA1877E8DA01D9824E@XY01EX22.xy01.xyratex.com>
	<20101209165030.GA2370@granier.hd.free.fr> <4D0138D8.3000505@cea.fr>
Message-ID: <1291932954.27484.5.camel@lap75545.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2010-12-09 at 21:15 +0100, Aur?lien Degr?mont wrote:
> But may be you could find it useful for internal process to know who 
> really comitted it, and in this case, it could be better to add a tag 
> 'c=' for committer, and git author is the real patch author.

Git keeps the committer information as well, and it may differ from the
patch author, so no need to call it out in the commit message.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
