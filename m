From: Eric Barton <eeb@sun.com>
Date: Thu, 25 Sep 2008 16:54:51 +0100
Subject: [Lustre-devel] Simpifying Interoperation
Message-ID: <CF0D4EA95C1945F18F74426BB95008CE@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Here are some first thoughts on Huang Hua's idea to simplify version
interoperation, and an invitation for further comments...

1. This scheme should not interfere with upgrade via failover pairs,
   and it must also allow the MDS to be upgraded separately from the
   OSSs.  I think this means in general that we have to allow
   piecemeal server upgrades.

2. This scheme need a mechanism that...

   a) notifies clients when a particular server is about to upgrade so
      that update operations are blocked until the upgrade completes
      and the client reconnects to the upgraded (and/or failed over)
      server.

   b) notifies the server when all clients have completed preparation
      for the upgrade so that no further requests require resend.

   c) notifies clients when all outstanding updates have been
      committed.  If the server crashes before this point, client
      replay is still required.  Clients must not poll for this since
      the server is shutting down.

   The DLM seems the right basic mechanism to notify clients, however
   current assumptions about acquisition timeouts might be an issue.

   We must also ensure that the race between this server upgrade
   process and connection establishment (including any new
   notification locks) by new clients is handled consistently.
   
3. It's not clear to me that we need to evict, or even clean the
   client cache provided the client doesn't attempt any more writes
   until it has connected to the failover server.  The client can
   re-acquire all the locks covering its cache during recovery after
   the upgrade - and there is no need for request refomatting here
   since locks are replayed explicitly (i.e. new requests are
   formatted from scratch using the correct protocol version).

   It does seem advisable however to clean the cache before such a
   significant system incident.

4. We can avoid reformatting requests during open replay if this is
   also done explicity.

5. This scheme prevents recovery on clients that were disconnected
   when the upgrade began.  Such clients will simply be evicted when
   they reconnect even though the server should actually have
   committed all their replayable requests.

   If this can be prevented, we can probably also dispense with much
   of the notification described in (2) above.  However it would
   require (a) a change in the connection protocol to get clients to
   purge their own replay queue and (b) changes to ensure resent
   requests can be reconstructed from scratch (but maybe (b) is just
   another way of saying "request reformatting").

   If this is doable - it further begs the question of whether simply
   making all server requests synchronous during upgrades is enough to
   simply most interoperation issues.

6. This is all about client/server communications. Are there any
   issues for inter-server interoperation?

7. Clients and servers may have to run with different versions for
   extended periods (one customer ran like this for months).  Does
   this raise any issues with this scheme?

    Cheers,
              Eric
