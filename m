From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 22 Jun 2011 11:59:52 -0600
Subject: [Lustre-devel] MDS recovery in Lustre
In-Reply-To: <BANLkTinomA6vF3N3oBQy64sH2tdZUtehyQ@mail.gmail.com>
References: <BANLkTinomA6vF3N3oBQy64sH2tdZUtehyQ@mail.gmail.com>
Message-ID: <BBB312B2-8E37-4E8D-BECF-6DA0431A72B3@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-06-21, at 9:44 PM, Jianwei Liao wrote:
> I am a new comer to Lustre.
> Recently, I have read some documents about Lustre file system and am interested in MDS recovery.
> 1) I was wondering that during MDS recovery(resend, and replay etc.), both the clients who involved in the recovery or the others(who are not involved in the recovery process) could access the MDS to get the file information or not.
> Simply speaking, during MDS recovery, is the MDS available or not?

No, during recovery for both the MDT and OST filesystems, only clients that
were previously connected are able to reconnect and perform operations, until
either recovery with all connected clients finishes, or recovery times out.
If recovery times out then clients which did not reconnect, or that did
reconnect or were unable to complete recovery, are evicted.

This avoids any problems with new clients connecting and changing the state
of the filesystem and causing RPC replay to fail.

> 2) Compared with non-VBR recovery, how about the time needed for MDS recovery while using VBR.

I don't think we've ever done any measurements of this.  I don't think it is
currently any faster, since only a single thread is doing the recovery.  In
theory, replay with VBR could be done in parallel because each object has
its own "replay stream" that is independently verified by VBR, but I don't
think that the time to replay the RPCs is a significant factor in the total
recovery time.

Currently, I believe most of the time is spent simply waiting for clients to
reconnect and begin recovery.  The "Imperative Recovery" project is working
to reduce this timeout significantly.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
