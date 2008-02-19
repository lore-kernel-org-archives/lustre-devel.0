From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 14:18:25 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAB962.8010901@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
Message-ID: <47BABB01.8060402@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Yuriy Umanets wrote:
> EA is separate block is evil. It makes things slow.

we have fast EAs (stored in inode, this is why we make them large) for years.

> Well, it did not in cmd3 :)

if it isn't stored in inode, it's a seek.

thanks, Alex
