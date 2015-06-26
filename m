From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 26 Jun 2015 09:05:57 +0200
Subject: [lustre-devel] [PATCH] staging:lustre: remove irq.h from
	socklnd.h
In-Reply-To: <1435265986-10375-1-git-send-email-jsimmons@infradead.org>
References: <1435265986-10375-1-git-send-email-jsimmons@infradead.org>
Message-ID: <CAMuHMdWrGr4SxRyLO9ELMFVUsRRD9rtirQ-n1m0NknGCoH0M5A@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 25, 2015 at 10:59 PM, James Simmons <jsimmons@infradead.org> wrote:
> The header socklnd.h includes irq.h which is not need
> and doesn't exist in the OpenSFS lustre branch. Having
> irq.h in socklnd.h does break the build on the m68k
> platform. So we can safely remove it.
>
> Signed-off-by: James Simmons <jsimmons@infradead.org>

Thanks, works fine on next-20150625!

Tested-by: by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert at linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
