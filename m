From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 17:42:13 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAE80A.8050702@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<47BAC7D4.3010007@sun.com> <47BAE80A.8050702@sun.com>
Message-ID: <47BAEAC5.3020805@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yuriy Umanets wrote:
> Alex Zhuravlev wrote:
>> btw, are you proposing to store LOV in global IAM?
> by "LOV" you mean LOV EA? If yes, well, this is too radical idea seems, 
> but it may be worse to think on. Finally using IAM with it will cost 
> almost nothing in meaning of additional development. IAM should be ready 
> for that.

it will cost additional seek to access something through IAM.
same applies to LOV and to epoch.

thanks, Alex
