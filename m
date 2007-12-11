From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 11 Dec 2007 11:25:39 -0700
Subject: [Lustre-devel] read ahead
Message-ID: <475ED623.6090204@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Can anyone tell me if read ahead in Lustre includes "early return" 
features.  I mean that if I read 4K and readahead decides to fetch 1M 
will my request get serviced when the first 4K arrives?  Is this important?

- Peter -
