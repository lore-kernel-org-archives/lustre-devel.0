From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Tue, 19 Feb 2008 19:21:19 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BABB01.8060402@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com>
Message-ID: <18363.511.252694.497169@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev writes:
 > 
 > Yuriy Umanets wrote:
 > > EA is separate block is evil. It makes things slow.
 > 
 > we have fast EAs (stored in inode, this is why we make them large) for years.
 > 
 > > Well, it did not in cmd3 :)
 > 
 > if it isn't stored in inode, it's a seek.

One possible point here is that OSD has to do fid->ino translation
anyway, and it makes sense to use the same index to store other
information besides inode number. That is, we can use "object index" iam
file to map fid into (ino, gen, ioepoch, LOV, ...) records, and this
would not cause any additional seeks. The downside here is that object
index is so heavily used, that making its records larger is going to
increase the amount of IO significantly, so it only worth to place there
things that we are absolutely sure will be needed for every inode.

 > 
 > thanks, Alex

Nikita.
