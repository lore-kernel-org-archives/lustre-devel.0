From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 17:47:29 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAE796.1040403@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<47BAC6FC.7020404@sun.com> <47BAE796.1040403@sun.com>
Message-ID: <47BAEC01.5050102@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yuriy Umanets wrote:
> Yes, this is what I understand as well. And we were discussing that EA 
> approach has some downsides. In fact what you propose, that is, store it 
> in EA is logical taking into account that epoch is kind of extension to 
> inode fields. It is property of inode-object. It is logical to store it 
> with inode, I see your point. But as we saw, this has/may have some 
> downsides which may be solved with IAM. Just take this in mind when you 
> think/work on it. I do not see why IAM is such a bad here.

1) additional seek(s)
2) shared structure (additional cost on concurrent access)
3) inode is already 512 bytes

thanks, Alex
