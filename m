From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Date: Wed, 15 Jun 2016 00:25:17 +0200
Subject: [lustre-devel] staging: lustre headers include outdated and wrong
	(c) information
Message-ID: <cf6e56c1-4ae4-d466-d7ea-446abcebdb21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Linux Driver Project Developer List <driverdev-devel@linuxdriverproject.org>, "<lustre-devel@lists.lustre.org> Development" <lustre-devel@lists.lustre.org>

It should be resolved ASAP.

This wrong/outdated info is in every staging/lustre file.

> /*
>  * GPL HEADER START
>  *
>  * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
>  *
>  * This program is free software; you can redistribute it and/or modify
>  * it under the terms of the GNU General Public License version 2 only,
>  * as published by the Free Software Foundation.
>  *
>  * This program is distributed in the hope that it will be useful, but
>  * WITHOUT ANY WARRANTY; without even the implied warranty of
>  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
>  * General Public License version 2 for more details (a copy is included
>  * in the LICENSE file that accompanied this code).
>  *
>  * You should have received a copy of the GNU General Public License
>  * version 2 along with this program; If not, see

That's OK.

>  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
>  *
>  * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
>  * CA 95054 USA or visit www.sun.com if you need additional information or
>  * have any questions.

But this must be removed/replaced.

>  *
>  * GPL HEADER END
>  */

-

> /*
>  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
>  * Use is subject to license terms.

And this must be replaced by the current (C) owner.

>  *
>  * Copyright (c) 2011, 2015, Intel Corporation.
>  */
> /*
>  * This file is part of Lustre, http://www.lustre.org/
>  * Lustre is a trademark of Sun Microsystems, Inc.
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ << ------ Also outdated.


References:

- http://www.oracle.com/us/corporate/press/018363
  Oracle Buys Sun

- https://www.xyratex.com/news/press-releases/xyratex-advances-lustre%C2%AE-initiative-assumes-ownership-related-assets
  "[...]
  Xyratex has recently acquired the original Lustre trademark, logo,
  website and associated intellectual property from Oracle, and will
  assume responsibility for providing support to Lustre customers going
  forward.
  [...]"

- https://www.xyratex.com/news/press-releases/seagate-completes-acquisition-xyratex
 "Seagate Completes Acquisition of Xyratex"

- http://lustre.org/about/
 "Lustre is a registered trademark of Seagate Technology LLC in the United States."


Thank you.
