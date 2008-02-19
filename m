From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 18:19:12 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAF252.9050409@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<op.t6r08rkfatmt0c@garden> <47BAF252.9050409@sun.com>
Message-ID: <47BAF370.7030804@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yuriy Umanets wrote:
> I did not mean to put whole inode in IAM. I meant only put there fid as 
> key and epoch as value. So way to access epoch is shorter with IAM as no 
> need to load inode. But these all need to be well thought as all your 
> mention more seeks, new reads, etc.

I don't understand benefits of this approach. the idea is to pack frequently
accessed data together so that we don't need additional seeks and load/store
these data with a single contiguous IO.

thanks, Alex
