From: =?utf-8?Q?J=C3=BCrgen_Kaiser?= <kaiserj@uni-mainz.de>
Date: Mon, 16 Jan 2017 16:28:15 +0100
Subject: [lustre-devel] Quality of Service Planning in Lustre
Message-ID: <A52473FD-8F0A-4684-BEA7-69C26C9F9519@uni-mainz.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello everyone,

my name is J?rgen Kaiser and I'm a research assistant at the Johannes Gutenberg University Mainz. As part of an IPCC project, we developed a tool for handling Quality of Service requirements in Lustre. We would like to explain what we did and hear your thoughts about it. We hope that our work will help the Lustre community in the future.

==== What we did ===

HPC centers typically use scheduling systems such as LSF or Slurm to manage the computations of the users and the resources themselves. These schedulers force the users to define compute jobs and to submit these jobs to the schedulers. In return, the schedulers guarantee the users that their job will have the required compute resources. So far, storage bandwidth is (mostly) excluded from the list of managed resources. Unlike resources like CPU or memory, there is no easy method for schedulers to handle storage bandwidth because they lack knowledge about storage system internals. For example, a scheduler must know the placement of a file?s data on Lustre's OSTs plus the workload as well as the maximum performance of the involved parts to reason about the available read throughput for the file.

It would be more practical if the storage system would provide a generic API for schedulers to set Quality of Service (QoS) configurations while abstracting the internal dependencies. With such an interface, a scheduler easily could request available storage         resources. In our project, we're developing a Quality of Service Planner (QoSP) that provides this interface. Its task is to receive storage bandwidth requests (e.g. 100MB/s read throughput for files X,Y,Z for one hour), check for resource availability and, if       available, guarantee the reserved resources by configuring Lustre. The main tool here is a (modified) TBF strategy in Lustre's NRS.

The QoSP still is under development. You can see the code on github: https://github.com/jkaiser/qos-planner . We see further use cases beyond the HPC scheduling scenario. For example, applications could negotiate I/O Phases with the storage backend (e.g. HPC checkpoints). We would like to hear your thoughts about this project in general and about several problems we face in detail. You can find a pdf a with detailed description and discussion about some core problems we face here: https://seafile.rlp.net/f/55e4c7b619/?raw=1. Two example issues are:

=== The NRS and the TBF ===

Users require _guaranteed_ storage bandwidth to reason about the run time of their applications so that they can reserve enough time on the computation cluster. In other words: users require minimum bandwidths instead of maximum ones. The current TBF strategy, however, only supports upper thresholds. There are two options here:
1) Implement minimums indirectly. This involves a monitoring of the actual resource consumption on the OSTs and a repeatedly readjusting of TBF rules.
2) Modify the TBF so that it supports lower thresholds. Here, the NRS would try to satisfy the minimums first. This additionally has the advantage that there is no underutilized bandwidth: each job can use free resources if necessary because there is no upper limit.

We would like to implement Option 2. We are in contact with DDN and discuss this work including the TBF strategy.

=== Handling Write Throughput ===

When an application requests write throughput, this usually means that it will create new files. However, at request time, these files do not exist yet, therefore the QoSP cannot know which OSTs will have to process the write throughput. Hence, the QoSP somehow must predict/determine the placement of new files on the OSTs within the Lustre system. This requires several modifications in Lustre including a new interface to query such information. We would like to discuss this issue with the Lustre community. The mentioned PDF file contains further details. We would be happy to hear your thoughts on this.

Best Regards,
J?rgen Kaiser
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 1536 bytes
Desc: Message signed with OpenPGP using GPGMail
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170116/f0342de4/attachment.pgp>
