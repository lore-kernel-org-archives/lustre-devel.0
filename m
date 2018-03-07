From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Wed, 07 Mar 2018 21:48:33 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: Remove VLA usage
In-Reply-To: <CAGXu5j+OTu84ohuR3f4_xKRw9vikVi-K2TnH3+n_ekX1m1Vv8A@mail.gmail.com>
 (Kees Cook's message of "Wed, 7 Mar 2018 09:20:31 -0800")
References: <20180307054608.GA9300@beast>
 <d5de0034-6f74-5b73-2df8-dbe5b366c2fc@prevas.dk>
 <CAGXu5j+OTu84ohuR3f4_xKRw9vikVi-K2TnH3+n_ekX1m1Vv8A@mail.gmail.com>
Message-ID: <87ina7ehni.fsf@rasmusvillemoes.dk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Rasmus Villemoes <rasmus.villemoes@prevas.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, "Tobin C. Harding" <me@tobin.cc>, Tycho Andersen <tycho@tycho.ws>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Gargi Sharma <gs051095@gmail.com>, Lustre Development List <lustre-devel@lists.lustre.org>, devel@driverdev.osuosl.org, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Mar 07 2018, Kees Cook <keescook@chromium.org> wrote:

> On Wed, Mar 7, 2018 at 5:10 AM, Rasmus Villemoes
> <rasmus.villemoes@prevas.dk> wrote:
>> On 2018-03-07 06:46, Kees Cook wrote:
>>> The kernel would like to remove all VLA usage. This switches to a
>>> simple kasprintf() instead.
>>>
>>
>> It's probably worth pointing out that this actually fixes an
>> unconditional buffer overflow: fullname only has room for the two
>> strings and the '\n', but vsnprintf() is told that the buffer has
>> infinite size (well, INT_MAX), so there should be plenty of room to
>> append the '\0' after the '\n'.
>>
>
> Oh yes, hah. I didn't even see the \n in the string. :P
>
> So, both a VLA fix and a buffer over-run fix. Can I add your "Reviewed-by"? :)

Sure,

Reviewed-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

A nit, if you're resending anyway: can you move the "char *fullname"
declarations down a bit, to between pv,valid, and lli,rc, respectively?
That keeps the initialized and uninitialized variables nicely together
and ends up looking better.
