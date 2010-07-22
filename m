From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Thu, 22 Jul 2010 15:07:18 -0400
Subject: [Lustre-devel] clio layer & portability
In-Reply-To: <AANLkTimly2Dz5LgHgCzF4qcHMdcfyZLl7s-EOXfwBLjl@mail.gmail.com>
Message-ID: <201007221907.o6MJ7IT8019207@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Yes, page index is a number a page has in a file that is divided in
>equally sized pages. One subtlety here is that a file (something that
>can be open(2)-ed) is striped over "stripe objects" and these also
>consist of pages. CLIO page is "layered": it binds together a file
>page and corresponding stripe object page.

Okay ... so, I take it the stripe objects are the reason for the
"parent" argument to cl_page_find0()?  I will confess that was always
a puzzler.

If anyone at Oracle could dig up that text document about CLIO that Nikita
is referring to, that sure would be helpful!  Although the presentation that
Alexey referrs to certainly is useful.

Thanks for everyone's help!  This has certainly been useful.

--Ken
