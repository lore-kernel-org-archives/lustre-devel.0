From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Oct 2016 00:29:59 +0200
Subject: [lustre-devel] [PATCH 08/28] staging: lustre: restore
	initialization of return code
In-Reply-To: <CY4PR11MB1751050A7C7AF840E94DDE60CBD00@CY4PR11MB1751.namprd11.prod.outlook.com>
References: <20161017220342.1627073-1-arnd@arndb.de>
	<20161017220903.1746743-2-arnd@arndb.de>
	<CY4PR11MB1751050A7C7AF840E94DDE60CBD00@CY4PR11MB1751.namprd11.prod.outlook.com>
Message-ID: <11209173.masZYIyEty@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Farrell <paf@cray.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Monday, October 17, 2016 10:23:00 PM CEST Patrick Farrell wrote:
> Arnd,
> 
> 
> The description and the actual patch don't seem to match up.  Am I missing something?

Sorry, I pasted the wrong error message when writing the changelog.

> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Arnd Bergmann <arnd@arndb.de>
> Sent: Monday, October 17, 2016 5:08:55 PM
> To: Oleg Drokin
> Cc: devel at driverdev.osuosl.org; Arnd Bergmann; Greg Kroah-Hartman; linux-kernel at vger.kernel.org; Linus Torvalds; lustre-devel at lists.lustre.org
> Subject: [lustre-devel] [PATCH 08/28] staging: lustre: restore initialization of return code
> 
> A recent rework removed the initialization of the successful return
> code from lpfc_write_firmware:
> 
> drivers/scsi/lpfc/lpfc_init.c: In function 'lpfc_write_firmware':
> drivers/scsi/lpfc/lpfc_init.c:10333:214: error: format '%ld' expects argument of type 'long int', but argument 9 has type 'size_t {aka const unsigned int}' [-Werror=format=]
> 
> This adds it back.


It should have been this warning:


drivers/staging/lustre/lustre/lov/lov_pack.c: In function 'lov_getstripe':
drivers/staging/lustre/lustre/lov/lov_pack.c:426:9: error: 'rc' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  return rc;
         ^~
drivers/staging/lustre/lustre/lov/lov_pack.c:313:6: note: 'rc' was declared here


	Arnd
