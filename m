From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Tue, 11 Dec 2007 21:42:13 +0300
Subject: [Lustre-devel] read ahead
In-Reply-To: <475ED623.6090204@sun.com>
References: <475ED623.6090204@sun.com>
Message-ID: <18270.55813.185376.299242@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam writes:
 > Can anyone tell me if read ahead in Lustre includes "early return" 
 > features.  I mean that if I read 4K and readahead decides to fetch 1M 
 > will my request get serviced when the first 4K arrives?  Is this important?

Currently read system call will proceed when the first RPC (including
first 4K page and some number of read-ahead pages) is serviced:
generic_file_read() waits on a page lock, and lock is released by
completion routine (ll_ap_completion()).

The problem with the "early return" (if I understood it correctly) is
that large read-ahead window is an indication of sequential access, and
in that case read is going to wait on the next page anyway.

 > 
 > - Peter -

Nikita.
