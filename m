From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Tue, 22 Apr 2008 21:03:59 +0400
Subject: [Lustre-devel] New Pools DLD
In-Reply-To: <019701c8a479$a2e42d40$0281a8c0@ebpc>
References: <20080225100425.GC3108@webber.adilger.int>
	<18373.20125.724151.421930@gargle.gargle.HOWL>
	<20080419002217.GC2775@webber.adilger.int>
	<019701c8a479$a2e42d40$0281a8c0@ebpc>
Message-ID: <18446.6783.368819.504719@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton writes:
 > Comment in-line below...
 > 
 > > -----Original Message-----
 > > From: lustre-devel-bounces at lists.lustre.org 
 > > [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of 
 > > Andreas Dilger

[...]

 > > Since we are already need to change the LOV_MAGIC value, we may as
 > > well do as you suggest and have 0x0BD3ssss instead of 0x0BD30BD0,
 > > where ssss = size of EA in bytes.
 > 
 > That seems a hack - why overload magic like this rather than have a
 > separate field?

Historically space in EA's was very scarce resource. Also, even a slight
increase in EA size might result in significant performance changes,
e.g., when EA's stop fitting into inode, and additional seek+read is
added to every inode load. So I tend to agree with Andreas that it makes
sense to replace __u32 magic with

        __u16 layout_type_id;
        __u16 layout_descriptor_size;

Nikita.
