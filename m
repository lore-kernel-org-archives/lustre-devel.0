From: Isaac Huang <he.huang@intel.com>
Date: Wed, 14 Aug 2013 17:13:53 -0600
Subject: [Lustre-devel] LND Development
In-Reply-To: <520B760A.7040205@stud.uni-heidelberg.de>
References: <520225E4.1070000@stud.uni-heidelberg.de>
	<20130807203914.GA1099@intel.com>
	<520B760A.7040205@stud.uni-heidelberg.de>
Message-ID: <20130814231353.GA1188@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Aug 14, 2013 at 02:20:26PM +0200, Tobias Groschup wrote:
> Thanks for the pointers!
> 
> The code of the loopback and Myrinet LND helped a great deal, as did
> more reading on the LNet API.
> After reading, I think that it is possible to implement an, albeit
> simple, LND in the limits of a master thesis.

The current ones have grown complex due to the LND protocol fixes over
the years and the constraint that LND wire protocol must be backward
compatible. There's also quirks in underlying protocol/hardware that
each LND had to deal with. A brand new one should not come even close
in complexity.

> If I have further questions about the development of a LND (and I am
> sure there will be more questions): is the lustre-devel mailing list
> the right place to ask? If not, where could I get help?

Please also CC:
https://lists.01.org/mailman/listinfo/hpdd-discuss

- Isaac
