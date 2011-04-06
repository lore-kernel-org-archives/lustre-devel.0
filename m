From: DEGREMONT Aurelien <aurelien.degremont@cea.fr>
Date: Wed, 06 Apr 2011 18:58:47 +0200
Subject: [Lustre-devel] llog API, locking and concurrency
Message-ID: <4D9C9BC7.5050603@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

I'm wondering what is the correct way to use llog_ API regarding locking 
and concurrencies?

When looking at code, it seems llog already deal with proper locking 
when several thread access the same llog.
The codes that use this king of log do not seem to add more locking when 
using it.

Is this correct? llog_* call can be called without taking care of 
concurrency?


Thanks

Aur?lien
