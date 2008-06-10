From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 10 Jun 2008 11:51:23 -0600
Subject: [Lustre-devel] Version based recovery
In-Reply-To: <200806092228.15908.alexander.zarochentsev@sun.com>
Message-ID: <C4741B3B.5A37%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



I quickly reviewed the HLD and read Mike's response.  Here are a few
questions:

1. Why do you wait for timeout+x after seeing a gap?  Why not x,timeout, or
y?

2. How to you avoid infinite accumulation of new exports?

3. If a VBR recovery operations happens, what transaction number is assigned
to this?   

4. Please discuss what happpens if multiple gaps are encountered?

5. Can we draw some pictures of the original transaction sequence and how
its slots are refilled (in what order, with what new transaction number etc)
if multiple clients are involved?


I believe that you might have the right algorithms, but the explanations in
the HLD are too short to be confident.

- Peter 
