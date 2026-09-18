using System;
using System.Collections.Generic;
using Officina.Events;
using Officina.Hubs;
using UnityEngine;

namespace Officina.Core
{
    // 씬 하나의 Manager 를 만들고 정리하는 자리다.
    // Update 는 없고 GameRunner 가 Process 를 부른다.
    public abstract class MasterBase : MonoBehaviour, IProcess, IFixedProcess, ILateProcess
    {
        private readonly List<IManager> _managers = new List<IManager>();
        private readonly ProcessList<IManager> _processList = new ProcessList<IManager>();

        // 넣는 순서가 곧 Init·Process 순서다.
        protected abstract void CreateManagers(List<IManager> into);

        // Manager 의 I~Hub 를 씬 Hub 에 등록하는 자리. owner 는 this 다.
        protected virtual void RegisterHubs() { }

        // RegisterHubs 에서 넣은 씬 Hub 를 여기서 뺀다. 안 빼면 씬 재진입 때 「이미 등록」 예외가 난다.
        protected virtual void UnregisterHubs() { }

        private void Awake()
        {
            CreateManagers(_managers);

            for (int i = 0; i < _managers.Count; i++)
            {
                _managers[i].Init();
            }

            RegisterHubs();

            for (int i = 0; i < _managers.Count; i++)
            {
                _managers[i].PostInit();
                _processList.Add(_managers[i]);
            }

            if (GameMaster.IsBooted)
            {
                GameMaster.Runner.AddMaster(this);
            }
        }

        public void Process(float deltaTime)
        {
            _processList.ProcessAll(deltaTime);
        }

        public void FixedProcess(float deltaTime)
        {
            _processList.FixedProcessAll(deltaTime);
        }

        public void LateProcess(float deltaTime)
        {
            _processList.LateProcessAll(deltaTime);
        }

        private void OnDestroy()
        {
            if (GameMaster.IsBooted)
            {
                GameMaster.Runner.RemoveMaster(this);
            }

            // 여기서 던지면 뒤가 통째로 안 거둬진다. 한 자리씩 막고 로그만 남긴다.
            try
            {
                UnregisterHubs();
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }

            GlobalHub.UnregisterAllBy(this);
            EventBus.UnsubscribeAllBy(this);

            // 거둘 때는 역순. 먼저 Init 된 것이 나중에 정리된다.
            // Manager 는 자기를 owner 로 구독하니 Master 것만 끊으면 남는다. 하나씩 끊어 준다.
            for (int i = _managers.Count - 1; i >= 0; i--)
            {
                IManager manager = _managers[i];
                try
                {
                    EventBus.UnsubscribeAllBy(manager);
                    manager.Dispose();
                }
                catch (Exception e)
                {
                    Debug.LogException(e);
                }
            }
            _managers.Clear();
        }
    }
}
