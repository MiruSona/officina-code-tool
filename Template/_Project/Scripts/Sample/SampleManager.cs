// 본보기다. 자기 Master 를 만들고 이 폴더를 지운다.
using System;
using Officina.Core;
using Officina.Events;
using Officina.Hubs;
using Officina.Resource;

namespace Officina.Sample
{
    public readonly struct SampleTickEvent
    {
        public readonly int Frame;

        public SampleTickEvent(int frame)
        {
            Frame = frame;
        }
    }

    public sealed class SampleManager : IManager, IProcess
    {
        private IResourceHub _resource;
        private EventSubscription _tickSubscription;
        private int _frame;

        // 자기 것만 챙긴다. Hub.Get 은 여기서 하지 않는다.
        public void Init()
        {
        }

        public void PostInit()
        {
            _resource = GlobalHub.Get<IResourceHub>();
            _tickSubscription = EventBus.Subscribe<SampleTickEvent>(this, OnTick);
        }

        public void Process(float deltaTime)
        {
            _frame++;
            EventBus.Publish(new SampleTickEvent(_frame));
        }

        // PostInit 에서 캐싱한 Hub 를 쓰는 자리. 예 : _resource.Rent<Transform>(PrefabKeys.Sample, null)
        private void OnTick(SampleTickEvent evt)
        {
            if (_resource == null)
            {
                throw new InvalidOperationException("PostInit 전에 이벤트를 받았다");
            }
        }

        public void Dispose()
        {
            if (_tickSubscription != null)
            {
                _tickSubscription.Dispose();
            }

            _tickSubscription = null;
        }
    }
}
