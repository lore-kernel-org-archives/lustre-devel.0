From: Alexey Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Fri, 05 Jun 2009 09:05:32 +0400
Subject: [Lustre-devel] [RFC] new activate/deactivate design
Message-ID: <1244178332.19922.23.camel@berloga.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

==== 0. create lov device. 

1) disk-obd need to be passed into attach method in order to use disk
operation in any lov method and to pass it to osc layer (for llog init,
as an example)

==== 1. add target to lov 

Process of adding a new target to lov is as follows: 
a) call osc to read llog CATALOG id and internally init llog subsystem
(done as part of bug 18800);
This step is need for avoid situation when we start replay requests
(unlink as an example) but llog subsystem isn't init in this time, so
can be have space leak in situation dual failure (client and mds
restart)

b) lov reads last objid from lov-objid file, adjusts max lov ea size and
notifies osc about its last known object id. If mds or llite will need
this, they can ask lov via get_info method;
How this counted in mdc/mds, but this need move knowledge about LOV EA
structure into mds/mdc layer, which is small layering problem.
 

c) add osc target to a global pool.


=== 2. ACTIVATE event 


2.1 activate notify event is converted from ptlrpc import event when
import changes its state to FULL. 
import changes its state from DISCONNECT to FULL in connect interpret,
which runs in ptlrpcd context, so should never be blocked. 

However connect interpret can block in the following cases:
1) client is evicted and need to flush own locks;
2) VBR failed and need to flush own locks;
3) need to send some events from connect FSM, which can block in
handlers.

So I think we need more generic way in order to avoid blocking in
connect interpret function, instead of having ll_sync thread on mds and
invalidate thread on ptlrpc layers - for this we need run some initial
checks and spawn new kernel thread, which can run connect FSM. This way
don't need own threads in mds (ll_sync thread) and invalidate thread and
avoid problems similar to blocking activate event in lov with delete osc
target, and also simplify the code. 


2.2 ACTIVATE event should be processed in the following order:
-> osc -> lov -> [llite | mds]. 


osc layer must be prepared before lov can work:
1) mark oscc as recovery mode, which indicates that create will be
permitted at near future. 
2) let ost know this is mds connection (via KEY_MDS_CONN or via connect
flag) 
3) connect mds llog to ost side and replay them. 
4) send event to lov layer 

lov should: 
1) mark target as active 
2) reset QoS penalty, so allow to select this ost in creation process 
3) pass event to upper layer (mds or llite) 

mds/llite should:
1) nothing now.

after this event is finished, a second event should be sent to osc -
recovery finished, which clears flag RECOVERY at oscc. 

3. remove OSC target 

3.1 
in some cases cluster administrator want to remove OST from cluster. In
this case OST should be deactivated on all clients and servers, and
removed from configuration. 

3.2 deactivate osc target 
To deactivate OSC target we need to send config llog update which
changes the state of 

osc and does following steps:
1) mark import as imp_deactive - this forbids pinger to send pings;
2) send special notify event DEACTIVATE, which should be:
a) mark target as deactivate on lov layer (disconnect should not touch
this flag!);
b) cancel all locks on this export, similar to invalidate, but without
discarding data, and LDLM_FL_LOCAL flag.


3.3 remove osc target 

To remove OST target, llog updates with remove target command should be
sent. After receiving this commands, a client or MDS should check that
this OST is deactivated and flush index from all pools. Then this LOV
target should be removed.

-- 
Alexey Lyashkov <Alexey.Lyashkov@Sun.COM>
Sun Microsystems
