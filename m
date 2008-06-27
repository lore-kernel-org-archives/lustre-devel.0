From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Fri, 27 Jun 2008 23:30:56 +0400
Subject: [Lustre-devel] [RFC] HLD Review Request: Interoperability
	at	server side
In-Reply-To: <C48A9A97.611F%peter.braam@sun.com>
References: <48632894.1050204@sun.com> <C48A9A97.611F%peter.braam@sun.com>
Message-ID: <18533.16368.39020.300723@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam writes:
 > Really good - well done!  I feel comfortable that this can move ahead.
 > 
 > I just want to ask you to make sure that repeated upgrade - downgrade -
 > upgrade events (in the case bugs in the new release force the user back to
 > old) are handled correctly.  I did see a discussion of up and down, but no
 > explicit mention of repeating that process multiple times.

This has been discussed, and the agreement was that some fixes (bug
15993) are needed in 1.8 server, so that it removes any remaining 2.0
state during downgrade.

 > 
 > Regards,
 > 
 > Peter
 > 

Nikita.
