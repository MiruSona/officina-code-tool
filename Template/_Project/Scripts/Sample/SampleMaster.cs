// 본보기다. 자기 Master 를 만들고 이 폴더를 지운다.
using System.Collections.Generic;
using Officina.Core;

namespace Officina.Sample
{
    public sealed class SampleMaster : MasterBase
    {
        // 넣는 순서가 곧 Init·Process 순서다.
        protected override void CreateManagers(List<IManager> into)
        {
            into.Add(new SampleManager());
        }

        // Manager 가 I~Hub 를 구현하면 InGameHub.Register<I~Hub>(manager, this) 를 여기 적는다.
        // SampleManager 는 I~Hub 가 없어 등록할 것이 없다.
        protected override void RegisterHubs()
        {
        }

        // RegisterHubs 에서 this 를 owner 로 넣은 것을 한 번에 뺀다.
        protected override void UnregisterHubs()
        {
            InGameHub.UnregisterAllBy(this);
        }
    }
}
