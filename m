From: Yuriy Umanets <Yury.Umanets@Sun.COM>
Date: Tue, 19 Feb 2008 16:44:14 +0200
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <18362.59753.121957.454081@gargle.gargle.HOWL>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<47BAC7D4.3010007@sun.com> <47BAE80A.8050702@sun.com>
	<18362.59753.121957.454081@gargle.gargle.HOWL>
Message-ID: <47BAEB3E.40309@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> Yuriy Umanets writes:
>  > Alex Zhuravlev wrote:
>  > > btw, are you proposing to store LOV in global IAM?
>  > by "LOV" you mean LOV EA? If yes, well, this is too radical idea seems, 
>  > but it may be worse to think on. Finally using IAM with it will cost 
>  > almost nothing in meaning of additional development. IAM should be ready 
>  > for that.
>  > 
>  > Nikita, is there any limitations for value size in IAM?
>
> Htree shift code will be upset if key+value are larger than one fourth
> of a block, but that's easy to fix.
>   
This is in fact interesting idea. An object (inode + EA, etc) always 
gets more and more info while adding new features and one day we will 
face the need to get rid of EA seems because it's too big.

Thanks.
>  
>  > 
>  > Thanks.
>
> Nikita.
>   


-- 
umka
