From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Thu, 22 Jul 2010 23:18:46 +0400
Subject: [Lustre-devel] clio layer & portability
In-Reply-To: <201007221907.o6MJ7IT8019207@hedwig.cmf.nrl.navy.mil>
References: <AANLkTimly2Dz5LgHgCzF4qcHMdcfyZLl7s-EOXfwBLjl@mail.gmail.com>
	<201007221907.o6MJ7IT8019207@hedwig.cmf.nrl.navy.mil>
Message-ID: <AANLkTinvHmhHrdsqhW8dSM3ktJ8OZb2VeaLthTIKh2fo@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 22 July 2010 23:07, Ken Hornstein <kenh@cmf.nrl.navy.mil> wrote:
>>Yes, page index is a number a page has in a file that is divided in
>>equally sized pages. One subtlety here is that a file (something that
>>can be open(2)-ed) is striped over "stripe objects" and these also
>>consist of pages. CLIO page is "layered": it binds together a file
>>page and corresponding stripe object page.
>
> Okay ... so, I take it the stripe objects are the reason for the
> "parent" argument to cl_page_find0()? ?I will confess that was always
> a puzzler.

Exactly.

>
> If anyone at Oracle could dig up that text document about CLIO that Nikita
> is referring to, that sure would be helpful! ?Although the presentation that
> Alexey referrs to certainly is useful.
>
> Thanks for everyone's help! ?This has certainly been useful.

Don't hesitate to ask.

>
> --Ken
>

Nikita.
