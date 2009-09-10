From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 10 Sep 2009 14:39:58 -0400
Subject: [Lustre-devel] Multithreaded liblustre
In-Reply-To: <68880AC1-3DDB-4B20-AE49-55227D64F295@swedisk.se>
References: <68880AC1-3DDB-4B20-AE49-55227D64F295@swedisk.se>
Message-ID: <EBD3008A-44E8-4A1E-A642-4777F7D206C7@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Sep 10, 2009, at 8:52 AM, Tuve Nordius wrote:
> Does anyone know what need to be done/ the main obstacles  in order to
> make liblustre multithreaded?

What sort of multi-threadness are you looking at?
Currently socklnd has separate threads if I remember right.
There are no callbacks and other async stuff happening, but that is
pretty much by design so would be hard to change.

Bye,
     Oleg
