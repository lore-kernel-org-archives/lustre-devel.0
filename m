From: Degremont, Aurelien <degremoa@amazon.com>
Date: Wed, 24 Jul 2019 07:23:46 +0000
Subject: [lustre-devel] [PATCH 10/11] lustre: ldlm: checkpatch cleanup
In-Reply-To: <alpine.LFD.2.21.1907240433050.12135@casper.infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
 <1563760338-806-11-git-send-email-jsimmons@infradead.org>
 <87tvbdjwa7.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1907240433050.12135@casper.infradead.org>
Message-ID: <1BDF7232-853F-4B2D-AC0B-AC49E78F6884@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



?Le 24/07/2019 05:38, ? lustre-devel au nom de James Simmons ? <lustre-devel-bounces at lists.lustre.org au nom de jsimmons@infradead.org> a ?crit :
    
    From checkpatch - "ENOSYS means 'invalid syscall nr' and nothing else"
    So using ENOSYS is no no. We get away with this because people rarely
    actually handle each error code individually.
.
    
As a general comment about this, I think we should improve this in the futur. Some people asked me "what's the error code when this or that happens in Lustre?". And I've got no real answer for that.
Indeed people, most of the time, only checks returned code against 0. That does not help when looking at specific Lustre issues.
