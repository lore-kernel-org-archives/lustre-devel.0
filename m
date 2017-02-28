From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 28 Feb 2017 20:00:57 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] [PATCH 4/5] staging: sm750fb:
 Remove unnecessary else after return
In-Reply-To: <CALrZqyNXbn1SZ8Daws7yKkYm-C-U9FHyJ_eRxvuem1Fk+Mqs=g@mail.gmail.com>
References: <1488219268-3006-1-git-send-email-singhalsimran0@gmail.com>
	<1488219268-3006-4-git-send-email-singhalsimran0@gmail.com>
	<alpine.DEB.2.20.1702272214410.2127@hadrien>
	<CALrZqyNXbn1SZ8Daws7yKkYm-C-U9FHyJ_eRxvuem1Fk+Mqs=g@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1702281959390.2171@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org, outreachy-kernel@googlegroups.com



On Wed, 1 Mar 2017, SIMRAN SINGHAL wrote:

> On Tue, Feb 28, 2017 at 2:45 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> >
> >
> > On Mon, 27 Feb 2017, simran singhal wrote:
> >
> >> This patch fixes the checkpatch warning that else is not generally
> >> useful after a break or return.
> >>
> >> This was done using Coccinelle:
> >> @@
> >> expression e2;
> >> statement s1;
> >> @@
> >> if(e2) { ... return ...; }
> >> -else
> >>          s1
> >>
> >> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> >> ---
> >>  drivers/staging/sm750fb/ddk750_sii164.c | 6 ++----
> >>  drivers/staging/sm750fb/ddk750_swi2c.c  | 6 ++----
> >>  2 files changed, 4 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/drivers/staging/sm750fb/ddk750_sii164.c b/drivers/staging/sm750fb/ddk750_sii164.c
> >> index 259006a..6906598 100644
> >> --- a/drivers/staging/sm750fb/ddk750_sii164.c
> >> +++ b/drivers/staging/sm750fb/ddk750_sii164.c
> >> @@ -368,8 +368,7 @@ unsigned char sii164IsConnected(void)
> >>       hotPlugValue = i2cReadReg(SII164_I2C_ADDRESS, SII164_DETECT) & SII164_DETECT_HOT_PLUG_STATUS_MASK;
> >>       if (hotPlugValue == SII164_DETECT_HOT_PLUG_STATUS_ON)
> >>               return 1;
> >> -     else
> >> -             return 0;
> >> +     return 0;
> >
> >
> > Totally unrelated to what you are doing, but I wonder if these return
> > values should be true and false?  Perhaps it would help to see how the
> > return values are used at the calling context.
> >
> you want me to go ahead with what Joe mentioned and also do the same
> changes here also.

I think that it would be best to complete what you have underway already.
When those patches are picked up by Greg, you can look into the
possibility of using true and false.

julia

> > julia
> >
> >>  }
> >>
> >>  /*
> >> @@ -387,8 +386,7 @@ unsigned char sii164CheckInterrupt(void)
> >>       detectReg = i2cReadReg(SII164_I2C_ADDRESS, SII164_DETECT) & SII164_DETECT_MONITOR_STATE_MASK;
> >>       if (detectReg == SII164_DETECT_MONITOR_STATE_CHANGE)
> >>               return 1;
> >> -     else
> >> -             return 0;
> >> +     return 0;
> >>  }
> >>
> >>  /*
> >> diff --git a/drivers/staging/sm750fb/ddk750_swi2c.c b/drivers/staging/sm750fb/ddk750_swi2c.c
> >> index a4ac07c..5997349 100644
> >> --- a/drivers/staging/sm750fb/ddk750_swi2c.c
> >> +++ b/drivers/staging/sm750fb/ddk750_swi2c.c
> >> @@ -199,8 +199,7 @@ static unsigned char sw_i2c_read_sda(void)
> >>       gpio_data = peek32(sw_i2c_data_gpio_data_reg);
> >>       if (gpio_data & (1 << sw_i2c_data_gpio))
> >>               return 1;
> >> -     else
> >> -             return 0;
> >> +     return 0;
> >>  }
> >>
> >>  /*
> >> @@ -295,8 +294,7 @@ static long sw_i2c_write_byte(unsigned char data)
> >>
> >>       if (i < 0xff)
> >>               return 0;
> >> -     else
> >> -             return -1;
> >> +     return -1;
> >>  }
> >>
> >>  /*
> >> --
> >> 2.7.4
> >>
> >> --
> >> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> >> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> >> To post to this group, send email to outreachy-kernel at googlegroups.com.
> >> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1488219268-3006-4-git-send-email-singhalsimran0%40gmail.com.
> >> For more options, visit https://groups.google.com/d/optout.
> >>
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> To post to this group, send email to outreachy-kernel at googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/CALrZqyNXbn1SZ8Daws7yKkYm-C-U9FHyJ_eRxvuem1Fk%2BMqs%3Dg%40mail.gmail.com.
> For more options, visit https://groups.google.com/d/optout.
>
