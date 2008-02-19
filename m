From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 19:27:51 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <18363.511.252694.497169@gargle.gargle.HOWL>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <18363.511.252694.497169@gargle.gargle.HOWL>
Message-ID: <47BB0387.2010802@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> One possible point here is that OSD has to do fid->ino translation
> anyway, and it makes sense to use the same index to store other
> information besides inode number. That is, we can use "object index" iam
> file to map fid into (ino, gen, ioepoch, LOV, ...) records, and this
> would not cause any additional seeks. The downside here is that object
> index is so heavily used, that making its records larger is going to
> increase the amount of IO significantly, so it only worth to place there
> things that we are absolutely sure will be needed for every inode.

well, we also need to update ioepoch when we update size/blocks.

thanks, Alex
