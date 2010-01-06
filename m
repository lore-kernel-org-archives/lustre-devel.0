From: Aleksandr Guzovskiy <Aleksandr.Guzovskiy@Sun.COM>
Date: Wed, 06 Jan 2010 11:51:48 -0500
Subject: [Lustre-devel] SOM questions
In-Reply-To: <078f01ca8e31$22ff9f80$68fede80$@com>
References: <078f01ca8e31$22ff9f80$68fede80$@com>
Message-ID: <4B44BFA4.3070603@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> Vitaly,
> 
> 1. Clients must replay opens on the MDS if "done writing" is still
>    pending to notify the new MDS that this file is volatile.  Does it
>    matter whether the client already sent "close" to the previous MDS
>    instance?  Does it have to send "close" again?
> 
> 2. I assume "done writing" is only sent after stripe updates have been
>    committed, not just executed so that cached SOM attributes are not
>    dependent on the client still being around to participate in
>    recovery if an OST fails.  Is this correct?

And this has the interaction with async data commit feature I brought up 
  during SC09 meetings i.e. client can't assume anymore OST IO is 
synchronous.

-Alex

> 
