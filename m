From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Jan 2019 21:57:15 +0000 (GMT)
Subject: [lustre-devel] [PATCH 00/14] lustre: fixes for many test
 failures
In-Reply-To: <87ftu5jbbm.fsf@notabene.neil.brown.name>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
 <87ftu5jbbm.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1901072153570.24234@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Sun, Jan 06 2019, James Simmons wrote:
> 
> > This patch series contains mostly fixes to resolve the majority of
> > the testing failures seen. Besides that are UAPI headers fixes to
> > prepare for when lustre will leave the staging tree. Include Neil's
> > dump_page_cache patch as well since it was landed in the OpenSFS
> > branch and the migration of lu_objects to rhashtables depended on
> > it.
> 
> Thanks - I've applied these.
> I haven't received all of the PFL series yet ... 16,17,18 still in limbo
> - so I haven't applied those yet.
> When the stragglers here here, I suspect they'll all go in.

Do you recieve patch 16,17,18 ? I do see they made it to the mailing list
archive :

http://lists.lustre.org/pipermail/lustre-devel-lustre.org/2019-January/thread.html

Also they are showing up at the patchwork site:

https://patchwork.kernel.org/project/lustre-devel/list

which is much easier to work with as a patch. Lastly if you need I can 
send you those patches directly to you again. Let me know what you want.
