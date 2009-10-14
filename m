From: Maxim V. Patlasov <Maxim.Patlasov@Sun.COM>
Date: Wed, 14 Oct 2009 19:22:36 +0400
Subject: [Lustre-devel] lustre-to-LNET API: big non-aligned bulk transfers
Message-ID: <4AD5ECBC.20003@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi lustre-devel,

I'd like to gather some opinions about the following question:

Is it allowed or possible for lustre to submit relatively big bulk 
transfer request (e.g. >512K) to LNET layer when offset in the very 
first page to fetch bulk data from (on sender side) is not equal to the 
offset in the very first page to store data (on receiver side)? In the 
other words - should LNET support such transfers?

Thanks in advance,
Maxim
